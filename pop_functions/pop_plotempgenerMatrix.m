% PURPOSE  : Plot temporal generalization matrix from MVPC data
%
% FORMAT   :
%
% >> pop_plotempgenerMatrix(MVPC);
%
% INPUTS (Required)  :
%
% MVPC or ALLMVPC       - input dataset (MVPCset) or input ALLMVCP
%
% Times                 - array of times (in milliseconds) to plot
%                           depending on the 'Type' input parameter.
%                         For example, [-200 800] will draw one plot that shows
%                         the temporal generalization matrix between -200ms and 800ms.
%

% The available parameters are as follows:
%
%        'MVPCindex' 	- Index of MVPCset(s) to use when contained
%                         within the ALLMVPC structure
%                         If supplying only one MVPCset using MVPC structure this value
%                         must be equal to 1 or left unspecified.
%                         Def: [1]
%
%        'FigSaveas'       - 'on'/'off'(def)
%
%        'Figpath'     - Path to save plots ('Saveas' must be 'on');
%                          default path: current working directory.
%
%        'Format'       -Format of saved file*: 'fig'(def)/'png'
%                         *('FigSaveas' must be 'on')
%
%        'Colormap' 	- Colormap for coloring of confusion matrix heatmap cells
%                       Predefined colormap options:
%                       {'default','viridis','gray','parula','cool', 'jet','hsv', 'hot' };
%
%
%
% EXAMPLE  :
%
% pop_plotempgenerMatrix( ALLMVPC,'MVPCindex', [ 11], 'Times', [-200 800],  'Format', 'fig', 'Colormap', 'default');
%
% See also: plotconfusions.mlapp
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Aaron Matthew Simmons
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022

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

function [mvpccom] = pop_plotempgenerMatrix(ALLMVPC,varargin);
mvpccom = '';
% MVPC = preloadMVPC;
if nargin<1
    help pop_plotempgenerMatrix
    return
end
if nargin == 1 %GUI

    currdata = evalin('base','CURRENTMVPC');

    if currdata == 0
        msgboxText =  'pop_plotempgenerMatrix() error: cannot work an empty dataset!!!';
        title1      = 'ERPLAB: No MVPC data';
        errorfound(msgboxText, title1);
        return
    end

    if ~iscell(ALLMVPC) && ~ischar(ALLMVPC)

        def  = erpworkingmemory('pop_plotempgenerMatrix');
        if isempty(def)
            def = {1, 1, [], 1,0,'',3,0,1};
            %def{1} = colormap
            %def{2} = format (1: fig, 2: png);
            %def{3} = times in [];
            %def{4} = save(1/def) or no save
        end



        %
        % Open plot confusion GUI
        %
        app = feval('plotTempGMGUI',ALLMVPC,currdata,def);
        waitfor(app,'FinishButton',1);

        try
            answer = app.output; %NO you don't want to output BEST, you want to output the parameters to run decoding
            app.delete; %delete app from view
            pause(0.5); %wait for app to leave
        catch
            disp('User selected Cancel');
            return
        end

        if isempty(answer)
            disp('User selected Cancel');
            return
        end

        plot_cmap     = answer{1};%plot_colormap
        tp =   answer{2}; % 0;1
        pname = answer{3};
        frmt = answer{4};
        savec = answer{5};
        %warnon    = answer {4};
        cmaps = {'default','viridis','gray','parula','cool', 'jet','hsv', 'hot' };
        frmts = {'fig','png','pdf','svg'};

        savefile =  answer{6};
        filepathname = answer{7};
        Decimal = answer{8};
        istime    = answer{9};
        tunit     = answer{10};


        %def = {actualnset, optioni, mvpcset,stderror};
        def = {plot_cmap,frmt, tp, savec,savefile,filepathname,Decimal,istime,tunit};
        erpworkingmemory('pop_plotempgenerMatrix', def);


        if savec == 1
            savestr = 'on';
        else
            savestr = 'off';
        end
        %
        % Somersault
        %
        if istime==1
            time = 'on';
        else
            time = 'off';
        end
        if  tunit==1
            tunitstr = 'milliseconds';
        else
            tunitstr = 'seconds';

        end

        if savefile
            Filesavestr = 'on';
        else
            Filesavestr = 'off';
        end


        ColorLimits = [];
        mvpccom =pop_plotempgenerMatrix(ALLMVPC, 'MVPCindex',currdata,'Times',tp, 'ColorLimits',ColorLimits,...
            'Figpath',pname, 'Colormap', cmaps{plot_cmap}, 'Format',frmts{frmt}, 'FigSaveas',savestr,...
            'FileSaveas',Filesavestr,'Filepath',filepathname,'Decimal',Decimal, 'time', time, 'timeunit', tunitstr,'History', 'gui');
        pause(0.1);
        return;
    else
        fprintf('pop_plotempgenerMatrix() was called using a single (non-struct) input argument.\n\n');
    end

end

p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLMVPC');
% option(s)
p.addParamValue('Times',[],@isnumeric);
p.addParamValue('MVPCindex', 1);               % same as Erpsets
p.addParamValue('Colormap', 'default', @ischar);
p.addParamValue('Format', 'fig', @ischar);
p.addParamValue('Figpath',pwd,@ischar);
p.addParamValue('FigSaveas', 'off', @ischar);     % 'on', 'off'
p.addParamValue('Warning', 'off', @ischar);    % 'on', 'off'
p.addParamValue('History', 'script', @ischar); % history from scripting
p.addParamValue('Tooltype','erplab',@ischar); %%GH, June 2024
p.addParamValue('ColorLimits',[],@isnumeric);
p.addParamValue('FileSaveas', 'off', @ischar);     % 'on', 'off' %%GH Jan 2026
p.addParamValue('Filepath',pwd,@ischar);%%GH Jan 2026
p.addParamValue('Decimal',3,@isnumeric);%%GH Jan 2026
p.addParamValue('time', 'off', @ischar);%%GH Jan 2026
p.addParamValue('timeunit', 'milliseconds', @ischar); %%GH Jan 2026


p.parse(ALLMVPC, varargin{:});
mvpci = p.Results.MVPCindex;
% meas = p.Results.Type;
tp = p.Results.Times;
cmap = p.Results.Colormap;
pname = p.Results.Figpath;
frmt = p.Results.Format;



if isempty(tp) || numel(tp)<2
    disp('Input parameter [Times] should be two numbers for this function!') ;
    return
end

if ismember_bc2({p.Results.FigSaveas}, {'on','yes'})
    issaveas  = 1;
else
    issaveas  = 0;
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


if isempty(mvpci)
    ALLMVPC = ALLMVPC(end);
else
    ALLMVPC = ALLMVPC(mvpci);
end


for Numofmvpc = 1:length(ALLMVPC)
    if length(ALLMVPC)==1
        MVPC = ALLMVPC;
    else
        MVPC = ALLMVPC(Numofmvpc);
    end
    if ~isfield(MVPC,'TGM') || isempty(MVPC.TGM)%%GH Dec. 2025;
        msgboxText =  'pop_plotempgenerMatrix() error: cannot work an empty dataset for temporal generalization matrix!!!';
        title1      = 'ERPLAB';
        errorfound(msgboxText, title1);
        return
    end
    cf_scores = MVPC.TGM;%%GH Dec. 2025;
    % cf_labels = MVPC.confusions.labels;
    % cf_strings = convertCharsToStrings(cf_labels);


    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% Time conversion
    %%%%%%%%%%%%%%%%%%%%%%%%%%%

    orig_times = MVPC.times;
    epoch_window = [orig_times(1) orig_times(end)];
    fs = MVPC.srate;
    xxlim = tp;

    if isempty(xxlim) | length(xxlim) <2
        msgboxText =  'You have not specified a time range';
        title1 = 'ERPLAB: latencies input';
        errorfound(msgboxText, title1);
        return
    end

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
        fprintf('\n%s\n', repmat('*',1,60));
        fprintf('WARNING: End time %.3f ms was adjusted to %.3f ms \n', xxlim(2), value);
        fprintf('WARNING: This adjustment was necessary due to sampling \n');
        fprintf('%s\n\n', repmat('*',1,60));
        aux_xxlim(2) = value;
    else
        aux_xxlim(2) = xxlim(2);
    end



    [xp1, xp2, checkw] = window2sample(MVPC, aux_xxlim(1:2) , fs, 'relaxed');
    if checkw==1
        msgboxText =  'Time window cannot be larger than epoch.';
        title1 = 'ERPLAB';
        errorfound(msgboxText, title1);
        return
    elseif checkw==2
        msgboxText =  'Too narrow time window (are the start and end times reversed?)';
        title1 = 'ERPLAB';
        errorfound(msgboxText, title1);
        return
    end

    %reset tp
    tp = aux_xxlim;

    %obtain time-point indices
    time_ind = [];
    for i = 1:numel(tp)
        time_ind(i) = find(tp(i) == orig_times);
    end


    %choose measurment & plot
    idx = time_ind(1):time_ind(2);
    cf_scores = cf_scores(idx,idx);
    % cf_scores = squeeze(mean(cf_scores,3));


    ColorLimits = p.Results.ColorLimits;%%GH July 2024
    if isempty(ColorLimits) || numel(ColorLimits)~=2 || min(ColorLimits(:))>1 || max(ColorLimits(:))<0
        ColorLimits = [];
    end


    %% plot
    if ~isempty(cf_scores)
        fig_gui = figure('Name',MVPC.mvpcname); %new figure for every plot
        % C = cf_scores(:,:,pnt);
        %C = flipud(C); %flips element values in matrix to align with Bae&Luck 2018, but doesn't flip row labels
        %cf_string2 = fliplr(cf_strings); % flips row labels

        %swap rows and columns of matrix as per Steve
        % Cnew = permute(C,[2 1]);
        % Cnew = flipud(Cnew);
        % cf_string2 = fliplr(cf_strings); % flips row labels

        pcolor(MVPC.times(idx),MVPC.times(idx),cf_scores);
        shading('flat');
        if ~strcmpi(cmap,'default')
            colormap(cmap);
        end
        h_clobar =  colorbar;
        if strcmpi(MVPC.DecodingUnit,'AUC')
            h_clobar.Label.String = 'AUC';
        else
            h_clobar.Label.String = 'ACC';
        end
        hold on;
        set(gca,'Color','w',...
            'XColor','k',...
            'YColor','k',...
            'ZColor','k',...
            'fontname','Helvetica');
        % set(gca,'TickDir','out');
        set(gca,'LineWidth',1);
        if ~isempty(ColorLimits) && numel(ColorLimits)==2 && ColorLimits(1) <ColorLimits(2)
            clim(ColorLimits);
        end
        % if ~isempty(ColorLimits) && numel(ColorLimits)==2
        %     h.ColorLimits = ColorLimits;%%GH July 2024
        % end
        %labels
        axis square;
        xlabel('Test time (ms)','fontname','Helvetica');
        ylabel('Train time (ms)','fontname','Helvetica');
        xline(0,'--','LineWidth',1);
        yline(0,'--','LineWidth',1);
        title(['Temporal Generalization Matrix'],'fontname','Helvetica','FontWeight','normal','Color','k'); %#ok<NODEF>
        hold off;
        set(fig_gui,'color',[1 1 1]);
    end


    if issaveas == 1
        fname = [pname,filesep, MVPC.mvpcname,'_TemporalGeneralizationMatrix_', num2str(tp(1)),'-',num2str(tp(2)),'ms'];
        % saveas(fig_gui, [fname,'.', frmt]);
        set(fig_gui, 'Renderer', 'painters');%%vector figure
        set(fig_gui,'PaperType','<custom>');
        % Set units to all be the same
        set(fig_gui,'PaperUnits','inches');
        set(fig_gui,'Units','inches');
        if strcmpi(frmt,'fig')%%GH Jan 2026
            saveas(fig_gui, [fname,'.fig'], frmt);
        elseif strcmpi(frmt,'png')
            print(fig_gui,'-dpng',[fname,'.png']);
        elseif strcmpi(frmt,'pdf')
            print(fig_gui,'-dpdf',[fname,'.pdf']);
        else
            print(fig_gui,'-dsvg',[fname,'.svg']);
        end
    end

end

% clear fig_gui ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%GH Jan 2026
if ismember_bc2({p.Results.FileSaveas}, {'on','yes'})
    fileissaveas  = 1;
else
    fileissaveas  = 0;
end
if fileissaveas==1
    if strcmpi(p.Results.Warning,'on')
        warnop = 1;
    else
        warnop = 0;
    end

    if strcmpi(p.Results.time, 'on')
        time = 1;
    else
        time = 0;
    end
    timeunit   = p.Results.timeunit;

    decimalNum = p.Results.Decimal;
    if isempty(decimalNum) || numel(decimalNum)~=1 || any(decimalNum(:)<1)
        decimalNum=3;
    end
    %choose measurment & plot
    fileNames = p.Results.Filepath;
    [pathstr, fileNames, ext] = fileparts(fileNames) ;

    if strcmpi(ext,'.xls')
        ext = '.xls';
    elseif strcmpi(ext,'.xlsx')
        ext = '.xlsx';
    else
        ext = '.txt';
    end
    if isempty(fileNames)
        fileNames = 'TemporalGeneralizationMatrix';
    end
    fileNames = char(strcat(pathstr,filesep,fileNames,ext));
    % try delete(fileNames);catch  end;

    if exist(fileNames, 'file')~=0 && warnop==1
        msgboxText =  ['This file that has the same name already exists.\n'...;
            'Would you like to overwrite it?'];
        title1  = 'ERPLAB pop_plotempgenerMatrix: WARNING!';
        button = askquest(sprintf(msgboxText), title1);
        if strcmpi(button,'no')
            disp('User canceled')
            return;
        end
    end

    f_exportfile_TemporalGeneralizationMatrix(ALLMVPC,[1:length(ALLMVPC)],time_ind,fileNames,tp,decimalNum,time,timeunit);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


skipfields = {'ALLMVPC','History'};


fn_old      = fieldnames(p.Results);
fn = {fn_old{1} fn_old{8} fn_old{9} fn_old{7} fn_old{5} fn_old{6} fn_old{4} fn_old{2} fn_old{3} fn_old{10} fn_old{11} fn_old{12} fn_old{13} fn_old{14} fn_old{15} fn_old{16}};
explica = 0;

if length(mvpci)==1 && mvpci(1)==1
    inputvari  = 'MVPC'; % Thanks to Felix Bacigalupo for this suggestion. Dic 12, 2011
    skipfields = [skipfields 'MVPCindex']; % SL
else
    if length(mvpci)==1
        explica   = 1;
    end
    inputvari = inputname(1);
end

if issaveas ~= 1
    skipfields = [skipfields {'Figpath','Format'}];
end

if fileissaveas~=1%%GH Jan 2026
    skipfields = [skipfields {'Filepath','Decimal','time','timeunit'}];
end


mvpccom = sprintf( 'mvpccom=pop_plotempgenerMatrix( %s', inputvari);
for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        if ~isempty(fn2res)
            if ischar(fn2res)
                % if ~strcmpi(fn2res,'off')
                mvpccom = sprintf( '%s, ''%s'', ''%s''', mvpccom, fn2com, fn2res);
                % end
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

                %                 if strcmpi(fn2com,'BESTindex')
                %                     bestcom = sprintf( ['%s, ''%s'', [', fnformat,']'], bestcom, fn2com, fn2resstr);
                %                 else
                mvpccom = sprintf( ['%s, ''%s'', ' fnformat], mvpccom, fn2com, fn2resstr);
                %                 end

                %bestcom = sprintf( ['%s, ''%s'', ' fnformat], bestcom, fn2com, fn2resstr);
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
        if explica
            try
                cprintf([0.1333, 0.5451, 0.1333], '%%IMPORTANT: For pop_plotempgenerMatrix(), you may use MVPC instead of ALLMVPC, and remove "''MVPCindex'',%g"\n',mvpci);
            catch
                fprintf('%%IMPORTANT: For pop_plotempgenerMatrix(), you may use MVPC instead of ALLMVPC, and remove ''MVCPindex'',%g:\n',mvpci);
            end
        end
    case 2 % from script
        % ERP = erphistory(ERP, [], bestcom, 1);
    case 3
        % implicit
    otherwise % off or none
        mvpccom = '';
end

return;