%write trial information to .text or .xls file



function erpcom =  pop_ERP_save_trial_information(ALLERP, varargin)

erpcom = '';
if nargin<1
    help pop_ERP_save_trial_information
    return
end

if nargin==1
    if isempty(ALLERP)
        msgboxText =  ['pop_ERP_save_trial_information: ALLERP is empty!'];
        titlNamerro = 'Error for pop_ERP_save_trial_information';
        estudio_warning(msgboxText,titlNamerro);
        return;
    end
    ERPArray = [1:length(ALLERP)];
    binArray = [1:ALLERP(1).nbin];
    
    erpcom =  pop_ERP_save_trial_information(ALLERP, 'ERPArray',ERPArray,'binArray',binArray,'History', 'gui');
    pause(0.01);
    return
end

p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLERP');

p.addParamValue('ERPArray', [], @isnumeric); %
p.addParamValue('binArray', [], @isnumeric);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ALLERP, varargin{:});
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

namedef ='Trial_information';
[erpfilename, erppathname, indxs] = uiputfile(formatname, ...
    ['Export trial information'],...
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



qERParray = p_Results.ERPArray;
ERPArray = qERParray;
if isempty(qERParray) || any(qERParray(:)>length(ALLERP)) || any(qERParray(:)<1)
    qERParray = 1:length(ALLERP);
end

qbinArray = p_Results.binArray;
binArray = qbinArray;

for Numoferp = 1:numel(qERParray)
    
    ERP = ALLERP(qERParray(Numoferp));
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
        columName1{1,1} = ['Name:',32,ERP.erpname];
        fprintf(fileID,'%s\n\n\n',columName1{1,:});
        
        %%Table title
        formatSpec2 =['%s\t',32,'%s\t',32,'%s\t',32,'%s\n'];
        columName2 = {'Bin', 'Included trials', 'Rejected trials', 'Invalid trials'};
        fprintf(fileID,formatSpec2,columName2{1,:});
        for ii = 1:length(qbinArray)
            try
                data{1,1} = [num2str(qbinArray(ii)),'.',ERP.EVENTLIST.bdf(qbinArray(ii)).description];
                data{1,2} =      [num2str(ERP.ntrials.accepted(qbinArray(ii))),];
                data{1,3} =     [num2str(ERP.ntrials.rejected(qbinArray(ii)))];
                data{1,4} =     [num2str(ERP.ntrials.invalid(qbinArray(ii)))];
                
            catch
                data{1,1} = '';
                data{1,2} =     '';
                data{1,3} =      '';
                data{1,4} =      '';
            end
            fprintf(fileID,formatSpec2,data{1,:});
        end
        
        if Numoferp~=length(ALLERP)
            data1{1,1} = '';
            data1{1,2} =     '';
            data1{1,3} =      '';
            data1{1,4} =      '';
            formatSpec3 =['%s\t',32,'%s\t',32,'%s\t',32,'%s\n\n\n\n\n\n'];
            fprintf(fileID,formatSpec3,data{1,:});
        end
    end
    
    %%xls file
    if write_spreadsheet==2
        data = [];
        binname =  '';
        columName2 = {ERP.erpname, 'Included trials', 'Rejected trials', 'Invalid trials'};
        for ii = 1:length(qbinArray)
            try
                data(ii,1) =      [ERP.ntrials.accepted(qbinArray(ii))];
                data(ii,2) =     [ERP.ntrials.rejected(qbinArray(ii))];
                data(ii,3) =     [ERP.ntrials.invalid(qbinArray(ii))];
            catch
                data(ii,1) =     [];
                data(ii,2) =     [];
                data(ii,3) =     [];
            end
            try
                binname{ii,1} = ERP.bindescr{qbinArray(ii)};
            catch
                binname{ii,1} = 'none';
            end
        end
        if Numoferp==1
            try
                blank_cell = {''};
                blank_T = table(blank_cell);
                writetable(blank_T, erpFilename,'Sheet',1,'Sheet', ['Data',32,num2str(Numoferp)]);
            catch
                msgboxText =  ['Excel XLS write server unavailible on this computer? We suggest exporting to a Matlab *.txt file instead.'];
                titlNamerro = 'Warning for pop_ERP_save_trial_information';
                estudio_warning(msgboxText,titlNamerro);
                return
            end
        end
        sheet_label_T = table(columName2);
        writetable(sheet_label_T,erpFilename,'Sheet',Numoferp,'Range','A1','WriteVariableNames',false,'Sheet', ['Data',32,num2str(Numoferp)]);
        xls_d = table(binname,data);
        writetable(xls_d,erpFilename,'Sheet',Numoferp,'Range','A2','WriteVariableNames',false,'Sheet', ['Data',32,num2str(Numoferp)]);  % write data
    end
end

if write_spreadsheet==1
    fclose(fileID);
end
disp(['A new file for trial information was created at <a href="matlab: open(''' erpFilename ''')">' erpFilename '</a>'])



skipfields = {'ALLERP', 'History'};

if isempty(ERPArray)
    skipfields = [skipfields,{'ERPArray'}];
end

if isempty(binArray)
    skipfields = [skipfields,{'binArray'}];
end

fn     = fieldnames(p.Results);
erpcom = sprintf( 'erpcom = pop_ERP_save_trial_information( %s',  'ALLERP');
for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off') && ~strcmpi(fn2res,'no')
                    erpcom = sprintf( '%s, ''%s'', ''%s''', erpcom, fn2com, fn2res);
                end
            else
                erpcom = sprintf( '%s, ''%s'', %s', erpcom, fn2com, vect2colon(fn2res,'Repeat','on'));
            end
        end
    end
end
erpcom = sprintf( '%s );', erpcom);

% get history from script. ERP
switch shist
    case 1 % from GUI
        displayEquiComERP(erpcom);
    case 2 % from script
        for i=1:length(ALLERP)
            ALLERP(i) = erphistory(ALLERP(i), [], erpcom, 1);
        end
    case 3
        % implicit
        %for i=1:length(ALLERP)
        %        ALLERP(i) = erphistory(ALLERP(i), [], erpcom, 1);
        %end
        %fprintf('%%Equivalent command:\n%s\n\n', erpcom);
    otherwise %off or none
        erpcom = '';
        return
end

end