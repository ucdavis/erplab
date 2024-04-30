%write trial information to .text or .xls file



function eegcom =  pop_eeg_save_trial_information(ALLEEG, varargin)

eegcom = '';
if nargin<1
    help pop_eeg_save_trial_information
    return
end

if nargin==1
    if isempty(ALLEEG)
        msgboxText =  ['pop_eeg_save_trial_information: ALLEEG is empty!'];
        titlNamerro = 'Error for pop_eeg_save_trial_information';
        estudio_warning(msgboxText,titlNamerro);
        return;
    end
    EEGArray = [1:length(ALLEEG)];
    binArray = [1:ALLEEG(1).EVENTLIST.nbin];
    
    eegcom =  pop_eeg_save_trial_information(ALLEEG, 'EEGArray',EEGArray,'binArray',binArray,'History', 'gui');
    pause(0.01);
    return
end

p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLEEG');

p.addParamValue('EEGArray', [], @isnumeric); %
p.addParamValue('binArray', [], @isnumeric);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ALLEEG, varargin{:});
p_Results = p.Results;

if strcmpi(p.Results.History,'implicit')
    shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
    shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
    shist = 1; % gui
else
    shist = 0; % off
end


BackERPLABcolor = [1 0.9 0.3];    % ERPLAB main window background
question = 'In order to see your summary, What would you like to do?';
title    = 'Artifact detection summary';
oldcolor = get(0,'DefaultUicontrolBackgroundColor');
set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
button = questdlg(question, title,'Save in a .txt file','Save in a .xls file', 'Cancel','Cancel');
set(0,'DefaultUicontrolBackgroundColor',oldcolor);

if strcmpi(button,'Save in a .txt file')
    write_spreadsheet=1;
    formatname = {'*.txt'};
elseif strcmpi(button,'Save in a .xls file')
    write_spreadsheet=2;
    formatname = {'*.xls';'*.xlsx'};
else
    return;
end

ERPtooltype = erpgettoolversion('tooltype');
if strcmpi(ERPtooltype,'EStudio')
    pathstr=  estudioworkingmemory('EEG_save_folder');
    if isempty(pathstr)
        pathstr = pwd;
    end
else
    pathstr = pwd;
end

namedef ='EEG_Trial_information';
[erpfilename, erppathname, indxs] = uiputfile(formatname, ...
    ['Export trial informationb for epoched EEG'],...
    fullfile(pathstr,namedef));
if isequal(erpfilename,0)
    return
end
if isequal(erpfilename,0)
    return
end

[pathstr, erpfilename, ext] = fileparts(erpfilename) ;
if write_spreadsheet==1
    ext = '.txt';
else
    if indxs==1
        ext = '.xls';
    elseif indxs==2
        ext = '.xlsx';
    else
        ext = '.xls';
    end
end

erpFilename = char(strcat(erppathname,erpfilename,ext));


qEEGArray = p_Results.EEGArray;
EEGArray = qEEGArray;
if isempty(qEEGArray) || any(qEEGArray(:)>length(ALLEEG)) || any(qEEGArray(:)<1)
    qEEGArray = 1:length(ALLEEG);
end

qbinArray = p_Results.binArray;
binArray = qbinArray;

for Numoferp = 1:numel(qEEGArray)
    
    EEG = ALLEEG(qEEGArray(Numoferp));
    [EEG, tprej, acce, rej, histoflags,  com] = pop_summary_AR_eeg_detection(EEG, 'none');
    ERP = pop_averager(EEG, 'Criterion', 'good', 'DSindex', 1, 'SEM', 'off');
    
    if isempty(qbinArray) || any(qbinArray(:)>ERP.nbin) || any(qbinArray(:)<1)
        qbinArray = [1:ERP.nbin];
    end
    %%txt file
    if write_spreadsheet==1
        if Numoferp==1
            fileID = fopen(erpFilename,'w+');
        end
        fprintf(fileID,'%s\n','*');
        fprintf(fileID,'%s\n','**');
        columName1{1,1} = ['Name:',32,EEG.setname];
        fprintf(fileID,'%s\n\n\n',columName1{1,:});
        
        %%Table title
        formatSpec2 =['%s\t',32,'%s\t',32,'%s\t',32,'%s\t',32,'%s\t',32,'%s\t',32,'%s\t',32,'%s\t',32,'%s\t',32,'%s\t',32,'%s\t',32,'%s\n'];
        columName2 = {'Bin', 'Total trials','Included trials', 'Rejected trials', 'Invalid trials','F2','F3','F4','F5','F6','F7','F8'};
        fprintf(fileID,formatSpec2,columName2{1,:});
        for ii = 1:length(qbinArray)
            try
                data{1,1} = [num2str(qbinArray(ii)),'.',ERP.bindescr{qbinArray(ii)}];
                data{1,2} =      [num2str(ERP.ntrials.accepted(qbinArray(ii))+ERP.ntrials.rejected(qbinArray(ii))+ERP.ntrials.invalid(qbinArray(ii)))];
                data{1,3} =      [num2str(ERP.ntrials.accepted(qbinArray(ii)))];
                data{1,4} =     [num2str(ERP.ntrials.rejected(qbinArray(ii)))];
                data{1,5} =     [num2str(ERP.ntrials.invalid(qbinArray(ii)))];
                data{ii,6} = [num2str(histoflags(ii,2))];%%F2
                data{ii,7} = [num2str(histoflags(ii,3))];%%F3
                data{ii,8} = [num2str(histoflags(ii,4))];
                data{ii,9} = [num2str(histoflags(ii,5))];
                data{ii,10} = [num2str(histoflags(ii,6))];
                data{ii,11} = [num2str(histoflags(ii,7))];
                data{ii,12} = [num2str(histoflags(ii,8))];
            catch
                data{1,1} = '';
                data{1,3} = '';
                data{1,4} = '';
                data{1,5} = '';
                data{ii,6} = '';%%F2
                data{ii,7} = '';%%F3
                data{ii,8} = '';
                data{ii,9} = '';
                data{ii,10} = '';
                data{ii,11} = '';
                data{ii,12} = '';
            end
            fprintf(fileID,formatSpec2,data{1,:});
        end
        
        if Numoferp~=length(ALLEEG)
            data1{1,1} = '';
            data1{1,2} = '';
            data1{1,3} = '';
            data1{1,4} = '';
            data1{1,5} = '';
            formatSpec3 =['%s\t',32,'%s\t',32,'%s\t',32,'%s\t',32,'%s\t',32,'%s\t',32,'%s\t',32,'%s\t',32,'%s\t',32,'%s\t',32,'%s\t','%s\n\n\n\n\n\n'];
            fprintf(fileID,formatSpec3,data{1,:});
        end
    end
    
    %%xls file
    if write_spreadsheet==2
        data = [];
        binname =  '';
        columName2 = {ERP.erpname,'Total trials','Included trials', 'Rejected trials', 'Invalid trials','F2','F3','F4','F5','F6','F7','F8'};
        for ii = 1:length(qbinArray)
            try
                data(ii,1) =      [ERP.ntrials.accepted(qbinArray(ii))+ERP.ntrials.rejected(qbinArray(ii))+ERP.ntrials.invalid(qbinArray(ii))];
                data(ii,2) =      [ERP.ntrials.accepted(qbinArray(ii))];
                data(ii,3) =     [ERP.ntrials.rejected(qbinArray(ii))];
                data(ii,4) =     [ERP.ntrials.invalid(qbinArray(ii))];
                data(ii,5) = histoflags(ii,2);%%F2
                data(ii,6) = histoflags(ii,3);%%F3
                data(ii,7) = histoflags(ii,4);
                data(ii,8) = histoflags(ii,5);
                data(ii,9) = histoflags(ii,6);
                data(ii,10) = histoflags(ii,7);
                data(ii,11) = histoflags(ii,8);
            catch
                data(ii,1) =     [];
                data(ii,2) =     [];
                data(ii,3) =     [];
                data(ii,4) =     [];
                data(ii,5) = [];%%F2
                data(ii,6) = [];%%F3
                data(ii,7) = [];
                data(ii,8) = [];
                data(ii,9) = [];
                data(ii,10) = [];
                data(ii,11) = [];
            end
            try
                binname{ii,1} = ERP.bindescr{qbinArray(ii)};
            catch
                binname{ii,1} = 'none';
            end
        end
        if Numoferp==1
        end
        sheet_label_T = table(columName2);
        sheetname = char(EEG.setname);
        if length(sheetname)>31
            sheetname = sheetname(1:31);
        end
        writetable(sheet_label_T,erpFilename,'Sheet',Numoferp,'Range','A1','WriteVariableNames',false,'Sheet',sheetname,"AutoFitWidth",false);
        xls_d = table(binname,data);
        writetable(xls_d,erpFilename,'Sheet',Numoferp,'Range','A2','WriteVariableNames',false,'Sheet',sheetname,"AutoFitWidth",false);  % write data
    end
end

if write_spreadsheet==1
    fclose(fileID);
end
disp(['A new file for trial information was created at <a href="matlab: open(''' erpFilename ''')">' erpFilename '</a>'])


skipfields = {'ALLEEG', 'History'};

if isempty(EEGArray)
    skipfields = [skipfields,{'EEGArray'}];
end

if isempty(binArray)
    skipfields = [skipfields,{'binArray'}];
end

fn     = fieldnames(p.Results);
eegcom = sprintf( 'eegcom = pop_eeg_save_trial_information( %s',  'ALLEEG');
for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off') && ~strcmpi(fn2res,'no')
                    eegcom = sprintf( '%s, ''%s'', ''%s''', eegcom, fn2com, fn2res);
                end
            else
                eegcom = sprintf( '%s, ''%s'', %s', eegcom, fn2com, vect2colon(fn2res,'Repeat','on'));
            end
        end
    end
end
eegcom = sprintf( '%s );', eegcom);

% get history from script. ERP
switch shist
    case 1 % from GUI
        displayEquiComERP(eegcom);
    case 2 % from script
        for i=1:length(ALLEEG)
            ALLEEG(i)=  eegh(eegcom, ALLEEG(i));
        end
    case 3
        
    otherwise %off or none
        eegcom = '';
        return
end

end