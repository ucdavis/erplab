% PURPOSE  : Plot confusion matricies from MVPC data 
%
% FORMAT   :
%
% >> pop_plotconfusions(MVPC, Times, Type)
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
% pop_plotconfusions( ALLMVPC, 'Times', [ 200], 'Type', 'timepoint', 'MVPCindex', [ 11], 'Format', 'fig', 'Colormap', 'default');
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

function pop_plotconfusions(ALLMVPC,Times,Type,varargin) 

MVPC = preloadMVPC; 

if nargin == 1 %GUI
    
    currdata = evalin('base','CURRENTMVPC'); 
    
    if currdata == 0 
        msgboxText =  'pop_plotconfusions() error: cannot work an empty dataset!!!';
        title      = 'ERPLAB: No MVPC data';
        errorfound(msgboxText, title);
        return
        
    end
    
    if ~iscell(ALLMVPC) && ~ischar(ALLMVPC)

        def  = erpworkingmemory('pop_plotconfusions');
        if isempty(def)
            def = {1 1 1 [] 1};
            %def{1} = plot menu (1: tp confusion 2:mean confusion two
            %                           latency)
            %def{2} = colormap
            %def{3} = format (1: fig, 2: png); 
            %def{4} = times in [];
            %def{5} = save(1/def) or no save
        end
        
        
  
        %
        % Open plot confusion GUI
        %
        app = feval('plotConfusionGUI',ALLMVPC,currdata,def); 
        waitfor(app,'FinishButton',1);
        
        try
            answer = app.output; %NO you don't want to output BEST, you want to output the parameters to run decoding
            app.delete; %delete app from view
            pause(0.5); %wait for app to leave
        catch
            disp('User selected Cancel')
            return
        end
    
        
        
        if isempty(answer)
            disp('User selected Cancel')
            return
        end
        
        plot_menu    = answer{1}; %plot_menu
        plot_cmap     = answer{2};%plot_colormap
        tp =   answer{3}; % 0;1
        pname = answer{4}; 
        frmt = answer{5};
        savec = answer{6}; 
        %warnon    = answer {4}; 
        cmaps = {'default','viridis','gray','parula','cool', 'jet','hsv', 'hot' };
        frmts = {'fig','png'}; 
        
%         if optioni==1 % from files
%             filelist    = mvpcset;
%             disp(['pop_gaverager(): For file-List, user selected ', filelist])
%             ALLMVPC = {ALLMVPC, filelist}; % truco
%         else % from mvpcsets menu
%             %mvpcset  = mvpcset;
%         end
        
        %def = {actualnset, optioni, mvpcset,stderror};
        def = {plot_menu, plot_cmap,frmt, tp, savec};
        erpworkingmemory('pop_plotconfusions', def);
%         if stderror==1
%             stdsstr = 'on';
%         else
%             stdsstr = 'off';
%         end
%         if warnon==1
%             warnon_str = 'on';
%         else
%             warnon_str = 'off';
%         end

        if plot_menu == 1
            %single timepoint confusion matrix
            meas = 'timepoint'; 
            
        elseif plot_menu==2
            %average across time window confusion matrix
            
            meas = 'average'; 
            
        end
        
        if savec == 1
            savestr = 'on';
        else
            savestr = 'off';
        end
            %
            % Somersault
            %

           pop_plotconfusions(ALLMVPC, 'Times',tp,'Type',meas, 'MVPCindex',currdata,...
               'filepath',pname, 'Colormap', cmaps{plot_cmap}, 'Format',frmts{frmt}, 'Saveas',savestr,'History', 'gui');
        pause(0.1)
        return
    else
        fprintf('pop_plotconfusions() was called using a single (non-struct) input argument.\n\n');
    end
    
    
    
    
end

p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLMVPC');
% option(s)
p.addParamValue('Times',[],@isnumeric);
p.addParamValue('Type',[],@ischar); 
p.addParamValue('MVPCindex', 1);               % same as Erpsets
p.addParamValue('Colormap', 'default', @ischar);
p.addParamValue('Format', 'fig', @ischar);
p.addParamValue('Filepath',pwd,@ischar); 
p.addParamValue('Saveas', 'off', @ischar);     % 'on', 'off'
p.addParamValue('Warning', 'off', @ischar);    % 'on', 'off'
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ALLMVPC, Times, Type, varargin{:});
mvpci = p.Results.MVPCindex;
meas = p.Results.Type;
tp = p.Results.Times;
cmap = p.Results.Colormap; 
pname = p.Results.Filepath;
frmt = p.Results.Format;

if isempty(meas)
   disp('Input paramter [Type] is empty for this function!') ;
   return
end

if isempty(tp)
    disp('Input paramter [Times] is empty for this function!') ;
    return
end

if ismember_bc2({p.Results.Saveas}, {'on','yes'})
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
    MVPC = ALLMVPC; 
else
    MVPC = ALLMVPC(mvpci); 
end

cf_scores = MVPC.confusions.scores;
cf_labels = MVPC.confusions.labels; 
cf_strings = convertCharsToStrings(cf_labels); 


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
        title = 'ERPLAB: latencies input';
        errorfound(msgboxText, title);
        %                 set(handles.radiobutton_yauto, 'Value',0)
        %                 drawnow
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


%% plot
for pnt = 1:Npts 
    
    figure; %new figure for every plot
    C = cf_scores(:,:,pnt); 
    %C = flipud(C); %flips element values in matrix to align with Bae&Luck 2018, but doesn't flip row labels
    %cf_string2 = fliplr(cf_strings); % flips row labels

    %swap rows and columns of matrix as per Steve
    Cnew = permute(C,[2 1]);
    Cnew = flipud(Cnew);
    cf_string2 = fliplr(cf_strings); % flips row labels
   
    h = heatmap(cf_strings,cf_string2,Cnew);
    if ~strcmpi(cmap,'default')
        h.Colormap = eval(cmap);
    end
    
    %labels
   
    if strcmpi(MVPC.DecodingMethod,'SVM')  
        if avg_win == 1
            h.Title = ['Confusion Matrix across ', num2str(tp(1)),'ms-',num2str(tp(2)), 'ms (Average Decoding Accuracy)'];
        else
            h.Title = ['Confusion Matrix @ ', num2str(tp(pnt)), ' ms (Average Decoding Accuracy)'];
            
        end
        
        h.YLabel = 'Predicted Labels';
        h.XLabel = 'True Labels';
    else 
        if avg_win == 1
            h.Title = ['Confusion Matrix across ', num2str(tp(1)),'ms-',num2str(tp(2)), 'ms (Average Distance)'];
        else
            h.Title = ['Confusion Matrix @ ', num2str(tp(pnt)), ' ms (Average Distance)'];
            
        end
        h.YLabel = 'Class';
        h.XLabel = 'Class';
    end
 
    
  if issaveas == 1
      if avg_win == 1
          fname = [pname '/ConfusionMatrix_', num2str(tp(1)),'-',num2str(tp(2)),'ms'];
      else
          fname = [pname '/ConfusionMatrix_', num2str(tp(pnt)) 'ms'];
      end
      saveas(h, fname, frmt);
      
  end
  clear h ;
end



skipfields = {'ALLMVPC','History'};


fn_old      = fieldnames(p.Results);
fn = {fn_old{1} fn_old{8} fn_old{9} fn_old{7} fn_old{5} fn_old{6} fn_old{4} fn_old{2} fn_old{3} fn_old{10}};
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
    skipfields = [skipfields 'Filepath']; 
end


mvpccom = sprintf( 'pop_plotconfusions( %s', inputvari);
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



switch shist
    case 1 % from GUI
        % fprintf('%%Equivalent command:\n%s\n\n', erpcom);
        displayEquiComERP(mvpccom);
        if explica
            try
                cprintf([0.1333, 0.5451, 0.1333], '%%IMPORTANT: For pop_plotconfusions(), you may use MVPC instead of ALLMVPC, and remove "''MVPCindex'',%g"\n',mvpci);
            catch
                fprintf('%%IMPORTANT: For pop_plotconfusions(), you may use MVPC instead of ALLMVPC, and remove ''MVCPindex'',%g:\n',mvpci);
            end
        end
    case 2 % from script
       % ERP = erphistory(ERP, [], bestcom, 1);
    case 3
        % implicit
    otherwise % off or none
        mvpccom = '';
end


end