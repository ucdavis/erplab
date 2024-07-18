% PURPOSE  : Plot confusion matricies from MVPC data
%
% FORMAT   :
%
% >> pop_exportconfusions(MVPC, Times, Type)
%
% INPUTS (Required)  :
%
% MVPC or ALLMVPC       - input dataset (MVPCset) or input ALLMVCP
%
% Times                 - array of times (in milliseconds) to plot
%                           depending on the 'Type' input paramter.
%
%                         If 'Type' is 'Timepoint', then output will be one
%                         plot for every timepoint included in the array.
%                         For example, [200 220 240] will draw three plots
%                         each at 200ms, 220ms, and 240ms.
%
%                         If 'Type' is 'Average', then output will be one
%                         plot averaged across the times in 'Times'. For
%                         example, [200 240] will draw one plot that shows
%                         the confusion matrix average across 200ms-240ms.
%
%
% Type                  - string 'Timepoint' OR 'Average'
%
%                        -Timepoint: Confusion matrix at a timepoint (specified in 'Times').
%                        -Average: Confusion matrix averaged across
%                        timepoints
%                        (specified in 'Times').
%
%
% The available parameters are as follows:
%
%        'MVPCindex' 	- Index of MVPCset(s) to use when contained
%                         within the ALLMVPC structure
%                         If supplying only one MVPCset using MVPC structure this value
%                         must be equal to 1 or left unspecified.
%                         Def: [1]
%
%        'Saveas'       - 'on'/'off'(def)
%
%        'Filepath'     - Path to save plots ('Saveas' must be 'on');
%                          default path: current working directory.
%
%        'Format'       -Format of saved file*: 'fig'(def)/'png'
%                         *('Saveas' must be 'on')
%
%        'Colormap' 	- Colormap for coloring of confusion matrix heatmap cells
%                       Predefined colormap options:
%                       {'default','viridis','gray','parula','cool', 'jet','hsv', 'hot' };
%
%
%
% EXAMPLE  :
%
% pop_exportconfusions( ALLMVPC, 'Times', [ 200], 'Type', 'timepoint', 'MVPCindex', [ 11], 'Format', 'fig', 'Colormap', 'default');
%
% See also: plotconfusions.mlapp
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Guanghui Zhang
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

function mvpccom = pop_exportconfusions(ALLMVPC,MVPCindex,varargin)
mvpccom = '';
if nargin<1
    help pop_exportconfusions
    return
end
if isempty(ALLMVPC)
    msgboxText =  'pop_exportconfusions() error: ALLMVPC is empty!!!';
    title      = 'ERPLAB: No MVPC data';
    errorfound(msgboxText, title);
    return
end
if nargin<2
    MVPCindex = [1:length(ALLMVPC)];
end
if isempty(MVPCindex) || any(MVPCindex(:)<1) || any(MVPCindex(:)>length(ALLMVPC))
    MVPCindex = [1:length(ALLMVPC)];
end

if nargin <3%GUI
    
    if ~iscell(ALLMVPC) && ~ischar(ALLMVPC)
        
        def  = erpworkingmemory('pop_exportconfusions');
        if isempty(def)
            pathName = pwd;
            def = {1,[],3,pathName};
        end
        
        %
        % Open plot confusion GUI
        %
        app = feval('Save_Confusion_file_GUI',ALLMVPC,MVPCindex,def);
        waitfor(app,'Finishbutton',1);
        try
            answer = app.Output; %NO you don't want to output BEST, you want to output the parameters to run decoding
            app.delete; %delete app from view
            pause(0.1); %wait for app to leave
        catch
            return
        end
        if isempty(answer)
            return
        end
        
        MVPCindex    = answer{1}; %plot_menu
        if isempty(MVPCindex) || any(MVPCindex(:)<1) || any(MVPCindex(:)>length(ALLMVPC))
            MVPCindex = [1:length(ALLMVPC)];
        end
        
        plot_menu =   answer{2}; % 0;1
        tp = answer{3};
        decimalNum = answer{4};
        fileNames = answer{5};
        
        %def = {actualnset, optioni, mvpcset,stderror};
        def = {plot_menu, tp, decimalNum, fileNames};
        erpworkingmemory('pop_exportconfusions', def);
        
        if plot_menu == 1
            %single timepoint confusion matrix
            meas = 'timepoint';
        elseif plot_menu==2
            %average across time window confusion matrix
            meas = 'average';
        end
        
        %
        % Somersault
        %
        pop_exportconfusions(ALLMVPC,MVPCindex, 'Times',tp,'Type',meas,...
            'fileNames',fileNames,'decimalNum',decimalNum,'History', 'gui');
        pause(0.1)
        return
    else
        fprintf('pop_exportconfusions() was called using a single (non-struct) input argument.\n\n');
    end
    
end

p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLMVPC');
p.addRequired('MVPCindex');
% option(s)
p.addParamValue('Times',[],@isnumeric);
p.addParamValue('Type',[],@ischar);
% p.addParamValue('MVPCindex', 1);               % same as Erpsets
p.addParamValue('fileNames','',@ischar);
p.addParamValue('decimalNum',3,@isnumeric);
p.addParamValue('Warning', 'off', @ischar);    % 'on', 'off'
p.addParamValue('History', 'script', @ischar); % history from scripting
p.addParamValue('Tooltype','erplab',@ischar); %%GH, June 2024
p.parse(ALLMVPC,MVPCindex, varargin{:});
MVPCArray = p.Results.MVPCindex;
meas = p.Results.Type;
tp = p.Results.Times;
fileNames = p.Results.fileNames;

if isempty(MVPCArray) || any(MVPCArray(:)<1) || any(MVPCArray(:)>length(ALLMVPC))
    MVPCArray = [1:length(ALLMVPC)];
end

decimalNum = p.Results.decimalNum;
if isempty(decimalNum) || numel(decimalNum)~=1 || any(decimalNum(:)<1)
    decimalNum=3;
end

[serror, msgboxText] = f_checkmvpc(ALLMVPC,MVPCArray);
if serror==1 || serror==2
    msgboxText =  'You have not specified a time range';
    title = 'ERPLAB: pop_exportconfusions() error';
    errorfound(msgboxText, title);
    return
end

if isempty(meas)
    disp('Input paramter [Type] is empty for this function!') ;
    return
end

if isempty(tp)
    disp('Input paramter [Times] is empty for this function!') ;
    return
end


%history
if strcmpi(p.Results.History,'implicit')
    shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
    shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
    shist = 1; % gui
else
    shist = 0; % off
end



MVPC = ALLMVPC(MVPCArray(1));

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Time conversions
%%%%%%%%%%%%%%%%%%%%%%%%%%%

orig_times = MVPC.times;
epoch_window = [orig_times(1) orig_times(end)];
fs = MVPC.srate;
xxlim = tp;


if strcmpi(meas,'average')
    if isempty(xxlim) | length(xxlim) <2
        msgboxText =  'You have not specified a time range';
        title = 'ERPLAB: pop_exportconfusions() latencies input';
        errorfound(msgboxText, title);
        return
    end
    
end

if strcmpi(meas,'timepoint')
    if numel(xxlim) == 1
        %only one timepoint
        if xxlim < round(epoch_window(1),2)
            % Revert to default time range
            tscale = epoch_window(1); %change from s to ms
            aux_xxlim = tscale;
            fprintf('\n%s\n', repmat('*',1,60));
            fprintf('WARNING: Time %.3f ms was adjusted to %.3f ms \n', xxlim, epoch_window(1));
            fprintf('WARNING: This adjustment was necessary due to sampling \n');
            fprintf('%s\n\n', repmat('*',1,60));
        elseif ~ismember(xxlim, round(orig_times,2))
            %check that time is actually within the data
            [value,ind] = closest(orig_times,xxlim);
            aux_xxlim = value;
            
            fprintf('\n%s\n', repmat('*',1,60));
            fprintf('WARNING: Time %.3f ms was adjusted to %.3f ms \n', xxlim, aux_xxlim);
            fprintf('WARNING: This adjustment was necessary due to sampling \n');
            fprintf('%s\n\n', repmat('*',1,60));
        else
            aux_xxlim = xxlim;
        end
    else
        %range of timepoints are input
        if xxlim(1) < round(epoch_window(1),2)
            % Revert to earliest time
            fprintf('\n%s\n', repmat('*',1,60));
            fprintf('WARNING: Lower limit %.3f ms was adjusted to %.3f ms \n', xxlim(1), epoch_window(1));
            fprintf('WARNING: This adjustment was necessary due to sampling \n');
            fprintf('%s\n\n', repmat('*',1,60));
            xxlim(1) = epoch_window(1);
        end
        
        check_vals = ismember(xxlim, round(orig_times,2));
        z = nnz(~check_vals);
        if z > 0
            %check that times are actually within the new
            %resampling period
            [value,ind] = closest(orig_times,xxlim);
            tscale = mat2colon(value,'delimiter','off');
            fprintf('\n%s\n', repmat('*',1,60));
            fprintf('WARNING: Times %s ms were adjusted to %s ms \n', ['[' num2str(xxlim) ']'], ['[' num2str(tscale) ']']);
            fprintf('WARNING: This adjustment was necessary due to sampling \n');
            fprintf('%s\n\n', repmat('*',1,60));
            aux_xxlim = value;
        else
            aux_xxlim = xxlim;
        end
    end
else
    %aveerage across two timepoints
    if xxlim(1) < round(epoch_window(1),2)
        
        % Revert to default time range
        tscale = epoch_window(1); %change from s to ms
        %aux_xxlim = tscale;
        
        fprintf('\n%s\n', repmat('*',1,60));
        fprintf('WARNING: Start time %.3f ms was adjusted to %.3f ms \n', xxlim(1), epoch_window(1));
        fprintf('WARNING: This adjustment was necessary due to sampling \n');
        fprintf('%s\n\n', repmat('*',1,60));
        aux_xxlim(1) = tscale;
    elseif ~ismember(xxlim(1), round(orig_times,2))
        %check that start time is actually within the new
        %resampling period
        
        [value,ind] = closest(orig_times,xxlim(1));
        
        %                 set(app.TPspinner,'Value',value);
        %                 app.TPspinner.Value = value;
        fprintf('\n%s\n', repmat('*',1,60));
        fprintf('WARNING: Start time %.3f ms was adjusted to %.3f ms \n', xxlim(1), value);
        fprintf('WARNING: This adjustment was necessary due to sampling \n');
        fprintf('%s\n\n', repmat('*',1,60));
        
        aux_xxlim(1) = value;
    else
        aux_xxlim(1) = xxlim(1);
    end
    
    if xxlim(2)> round(epoch_window(end),2)
        
        tscale(2) = epoch_window(end);
        
        fprintf('\n%s\n', repmat('*',1,60));
        fprintf('WARNING: End time %.3f ms was adjusted to %.3f ms \n', xxlim(2), tscale(2));
        fprintf('WARNING: This adjustment was necessary due to sampling \n');
        fprintf('%s\n\n', repmat('*',1,60));
        
        aux_xxlim(2)=  tscale(2);
        
    elseif ~ismember(xxlim(2), round(orig_times,2))
        %check that end time is actually within the new
        %resampling period
        
        [value,ind] = closest(orig_times,xxlim(2));
        
        %                 set(app.TPspinner,'Value',value);
        %                 app.TPspinner.Value = value;
        fprintf('\n%s\n', repmat('*',1,60));
        fprintf('WARNING: End time %.3f ms was adjusted to %.3f ms \n', xxlim(2), value);
        fprintf('WARNING: This adjustment was necessary due to sampling \n');
        fprintf('%s\n\n', repmat('*',1,60));
        
        aux_xxlim(2) = value;
        
    else
        aux_xxlim(2) = xxlim(2);
    end
end


if strcmpi(meas,'average')
    [xp1, xp2, checkw] = window2sample(MVPC, aux_xxlim(1:2) , fs, 'relaxed');
    if checkw==1
        msgboxText =  'Time window cannot be larger than epoch.';
        title = 'ERPLAB';
        errorfound(msgboxText, title);
        return
    elseif checkw==2
        msgboxText =  'Too narrow time window (are the start and end times reversed?)';
        title = 'ERPLAB';
        errorfound(msgboxText, title);
        return
    end
end

%reset tp
tp = aux_xxlim;

%obtain time-point indices
time_ind = [];
for i = 1:numel(tp)
    time_ind(i) = find(tp(i) == orig_times);
end
avg_win = 0 ;
%choose measurment & plot

[pathstr, fileNames, ext] = fileparts(fileNames) ;

if strcmpi(ext,'.xls')
    ext = '.xls';
elseif strcmpi(ext,'.xlsx')
    ext = '.xlsx';
else
    ext = '.txt';
end
if isempty(fileNames)
    fileNames = 'Confusion_matrix';
end
fileNames = char(strcat(pathstr,filesep,fileNames,ext));
try delete(fileNames);catch  end;


for Numofmvpc = 1:numel(MVPCArray)
    %% plot
    MVPC = ALLMVPC(MVPCArray(Numofmvpc));
    cf_scores = MVPC.confusions.scores;
    cf_labels = MVPC.confusions.labels;
    cf_strings = convertCharsToStrings(cf_labels);
    if strcmpi(meas,'timepoint')
        if numel(time_ind) == 1
            cf_scores = cf_scores(:,:,time_ind);
            Npts = 1;
        else
            %multiple plots at 1 time point
            cf_scores = cf_scores(:,:,time_ind);
            Npts = numel(time_ind);
        end
    elseif strcmpi(meas,'average')
        idx = time_ind(1):time_ind(2);
        cf_scores = cf_scores(:,:,idx);
        cf_scores = squeeze(mean(cf_scores,3));
        Npts = 1;
        avg_win = 1;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%---------------Save the confusin matrix to .txt file-----------------
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strcmpi(ext,'.txt')
        if Numofmvpc==1
            fileID = fopen(fileNames,'w+');
        end
        fprintf(fileID,'%s\n','*');
        fprintf(fileID,'%s\n','**');
        columName1{1,1} = ['MVPC Name:',32,MVPC.mvpcname];
        fprintf(fileID,'%s\n\n',columName1{1,:});
        
        for pnt = 1:Npts%%
            if strcmpi(MVPC.DecodingMethod,'SVM')
                if avg_win == 1
                    TitleNames = [ num2str(tp(1)),'ms-',num2str(tp(2)), 'ms (Average Decoding Accuracy)'];
                else
                    TitleNames = ['@ ', num2str(tp(pnt)), ' ms (Average Decoding Accuracy)'];
                end
            else
                if avg_win == 1
                    TitleNames = [ num2str(tp(1)),'ms-',num2str(tp(2)), 'ms (Average Distance)'];
                else
                    TitleNames = ['@ ', num2str(tp(pnt)), ' ms (Average Distance)'];
                end
            end
            
            C = cf_scores(:,:,pnt);
            %swap rows and columns of matrix as per
            Cnew = permute(C,[2 1]);
            Cnew = flipud(Cnew);
            cf_string2 = fliplr(cf_strings); % flips row labels
            columName2{1,1} = TitleNames;
            formatSpec2 = '';
            for Numofcolumns = 1:size(Cnew,2)
                columName2{1,Numofcolumns+1} = cf_strings{Numofcolumns};
                formatSpec2 =[formatSpec2,'%s\t',32];
            end
            formatSpec2 = [formatSpec2,'%s\n'];
            fprintf(fileID,formatSpec2,columName2{1,:});
            for Numofrow = 1:size(Cnew,1)
                data = [];
                data{1,1} = cf_string2{Numofrow};
                for Numofcolumn = 1:size(Cnew,2)
                    data{1,Numofcolumn+1} = sprintf(['%.',num2str(decimalNum),'f'],Cnew(Numofrow,Numofcolumn));
                end
                fprintf(fileID,formatSpec2,data{1,:});
            end
            fprintf(fileID,'%s\n',' ');%%empty
        end
        fprintf(fileID,'%s\n\n\n','');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%---------------Save the confusin matrix to .xls file-----------------
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%xls file
    if ~strcmpi(ext,'.txt')
        for pnt = 1:Npts%%
            data = [];
            binname =  '';
            if strcmpi(MVPC.DecodingMethod,'SVM')
                if avg_win == 1
                    TitleNames = [ num2str(tp(1)),'ms-',num2str(tp(2)), 'ms (Average Decoding Accuracy)'];
                else
                    TitleNames = ['@ ', num2str(tp(pnt)), ' ms (Average Decoding Accuracy)'];
                end
            else
                if avg_win == 1
                    TitleNames = [ num2str(tp(1)),'ms-',num2str(tp(2)), 'ms (Average Distance)'];
                else
                    TitleNames = ['@ ', num2str(tp(pnt)), ' ms (Average Distance)'];
                end
            end
            
            C = cf_scores(:,:,pnt);
            %swap rows and columns of matrix as per
            Cnew = permute(C,[2 1]);
            Cnew = flipud(Cnew);
            cf_string2 = fliplr(cf_strings); % flips row labels
            columName2{1,1} = TitleNames;
            
            for Numofcolumns = 1:size(Cnew,2)
                columName2{1,Numofcolumns+1} = cf_strings{Numofcolumns};
            end
            
            sheet_label_T = table(columName2);
            sheetname = char(MVPC.mvpcname);
            if length(sheetname)>31
                sheetname = sheetname(1:31);
            end
            rowNum = size(Cnew,1);
            for rowss = 1:size(Cnew,1)
                for columnss = 1:size(Cnew,2)
                    Cnewstr{rowss,columnss} = sprintf(['%.',num2str(decimalNum),'f'],Cnew(rowss,columnss));
                end
            end
            
            startrows = 1+rowNum*(pnt-1)+(pnt-1)*2;
            writetable(sheet_label_T,fileNames,'Sheet',Numofmvpc,'Range',['A',num2str(startrows)],'WriteVariableNames',false,'Sheet',sheetname,"AutoFitWidth",false);
            xls_d = table(cf_string2',Cnewstr);
            writetable(xls_d,fileNames,'Sheet',Numofmvpc,'Range',['A',num2str(startrows+1)],'WriteVariableNames',false,'Sheet',sheetname,"AutoFitWidth",false);  % write data
        end
    end
    
    
    
end
if strcmpi(ext,'.txt')
    fclose(fileID);
end
disp(['A new file for confusion matrix was created at <a href="matlab: open(''' fileNames ''')">' fileNames '</a>'])


skipfields = {'ALLMVPC','History','MVPCindex'};


fn = fieldnames(p.Results);%{fn_old{1} fn_old{8} fn_old{9} fn_old{7} fn_old{5} fn_old{6} fn_old{4} fn_old{2} fn_old{3} fn_old{10}};


MVPCindexstr = vect2colon(MVPCindex);

mvpccom = sprintf( 'pop_exportconfusions( %s, %s', 'ALLMVPC',MVPCindexstr);
for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off')
                    mvpccom = sprintf( '%s, ''%s'', ''%s''', mvpccom, fn2com, fn2res);
                end
            else
                if iscell(fn2res)
                    if all(cellfun(@isnumeric, fn2res))
                        %fn2resstr = vect2colon(cell2mat(fn2res), 'Sort','on');
                        fn2resstr =cell2mat(cellfun(@vect2colon,fn2res,'UniformOutput',false));
                    else
                        fn2resstr = '';
                        for kk=1:numel(fn2res)
                            auxcont = fn2res{kk};
                            if ischar(auxcont)
                                fn2resstr = [fn2resstr '''' auxcont ''',' ];
                            else
                                fn2resstr = [fn2resstr ' ' vect2colon(auxcont, 'Delimiter', 'on')];
                            end
                            
                        end
                        fn2resstr(end) = []; %take out last comma
                        
                    end
                    fnformat = '{%s}';
                elseif isnumeric(fn2res)
                    fn2res = mat2colon(fn2res);
                    fn2resstr = num2str(fn2res); fnformat = '%s';
                elseif isstruct(fn2res)
                    fn2resstr = 'ALLMVPC'; fnformat = '%s';
                else
                    fn2resstr = vect2colon(fn2res, 'Sort','on');
                    fnformat = '%s';
                end
                mvpccom = sprintf( ['%s, ''%s'', ' fnformat], mvpccom, fn2com, fn2resstr);
            end
        end
    end
end
mvpccom = sprintf( '%s );', mvpccom);
Tooltype = p.Results.Tooltype;%%GH, June 2024
if isempty(Tooltype)%%GH, June 2024
    Tooltype = 'erplab';
end
if strcmpi(Tooltype,'erplab')%%GH, June 2024
    eegh(mvpccom);
end


switch shist
    case 1 % from GUI
        % fprintf('%%Equivalent command:\n%s\n\n', erpcom);
        displayEquiComERP(mvpccom);
        
    case 2 % from script
        % ERP = erphistory(ERP, [], bestcom, 1);
    case 3
        % implicit
    otherwise % off or none
        mvpccom = '';
end

end